--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------
	Localization 	: 	/Datas/datas.lua 
    Original Author	:	Vvarderen
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

local L = CurvyHud:GetLoc()

CurvyHud.allianceIcons = {
	[1]	= "aldmeri",  	-- AD
	[2]	= "ebonheart",  -- EP
	[3] = "daggerfall", -- DC
}

CurvyHud.classIcons = {
	[1]	= "dknight", 	-- DK
	[2]	= "sorcerer", 	-- SO
	[3] = "nightblade", -- NB
	[4]	= "warden",  	-- WD
	[5]	= "necro",		-- NC
--	[5]	= "batllemage", -- BM
	[6]	= "templar",  	-- TP

}

CurvyHud.raceIcons = {
	[1] = "breton",
	[2] = "redguard",
	[3] = "orc",
	[4] = "dunmer",
	[5] = "nord",
	[6] = "argonian",
	[7] = "altmer",
	[8] = "bosmer",
	[9] = "khajiit",
	[10]= "imperial",
}

CurvyHud.deadInDungeon = {
	[1] = L.DeadDungeonA,
	[2] = L.DeadDungeonB,
	[3] = L.DeadDungeonC,
	[4] = L.DeadDungeonD,
	[5] = L.DeadDungeonE,
	[6] = L.DeadDungeonF,
	[7] = L.DeadDungeonG,
	[8] = L.DeadDungeonH,
	[9] = L.DeadDungeonI,
	[10]= L.DeadDungeonJ,
	[11]= L.DeadDungeonK,
}

CurvyHud.deadInWorld = {
	[1] = L.DeadInWorldA,
	[2] = L.DeadInWorldB,
	[3] = L.DeadInWorldC,
	[4] = L.DeadInWorldD,
	[5] = L.DeadInWorldE,
	[6] = L.DeadInWorldF,
	[7] = L.DeadInWorldG,
	[8] = L.DeadInWorldH,
	[9] = L.DeadInWorldI,
	[10]= L.DeadInWorldJ,
	[11]= L.DeadInWorldK,
}

CurvyHud.dungeonDiff = {

	[1] = L.DungeonNormalDiff,
	[2] = L.DungeonVetDiff, 
}

CurvyHud.colorTable	= {
	["white"] 		= {255/255,  255/255,  255/255,  1},
	["whiteReticle"]= {255/255,  255/255,  255/255,  0.3},
	["gold"]		= {245/255,  245/255,  185/255,  1},
	["silver"]		= {190/255,  190/255,  190/255,  1},
	["grey"] 		= {200/255,  200/255,  200/255,  0.8},
	["red"]			= {180/255,  50 /255,  50 /255,  1},
	["yellow"]		= {200/255,  200/255,  80 /255,  1},
	["pureYellow"]	= {255/255,  255/255,  0  /255,  1},
	["blue"]		= {80 /255,  140/255,  255/255,  1},
	["bluePlayer"]	= {85 /255,  190/255,  255/255,  1},	
	["orange"]		= {250/255,  140/255,  0  /255,  1},
	["DarkOrange"]	= {210/255,  80 /255,  50 /255,  1},	
	["green"]		= {0  /255,  255/255,  0  /255,	 1},
	["pureRed"] 	= {255/255,  0  /255,  0  /255,  1},
	["purpleHight"] = {120/255,  90 /255,  130/255,  0.9},
	["purpleLow"]	= {120/255,  90 /255,  130/255,  0.2},
	["none"]		= {0  /255,  0  /255,  0  /255,  0},
	["sky"]			= {185/255,  245/255,  245/255,  1},
	["grass"]		= {180/255,  255/255,  190/255,  1},
	["mauve"]		= {200/255,  200/255,  255/255,  1},
	["titleColor"] 	= "|c7B18FF", 
	["divColor"]	= "|ca866ff", 
	["headerColor"] = "|c922BFF", 
}

-- bars/attribute mapping, 
CurvyHud.barPowertypeMapping = {
	["healthBar"] 	= POWERTYPE_HEALTH, 
	["staminaBar"] 	= POWERTYPE_STAMINA, 
	["magickaBar"] 	= POWERTYPE_MAGICKA, 
	["mountBar"] 	= POWERTYPE_MOUNT_STAMINA, 
	["werewolfBar"] = POWERTYPE_WEREWOLF, 
}

-- attribute/bars mapping, 
CurvyHud.powerTypeBarMapping = {
	[POWERTYPE_HEALTH] 			= "healthBar", 
	[POWERTYPE_STAMINA] 		= "staminaBar", 
	[POWERTYPE_MAGICKA] 		= "magickaBar", 
	[POWERTYPE_MOUNT_STAMINA] 	= "mountBar", 
	[POWERTYPE_WEREWOLF]		= "werewolfBar", 
}

-- stat type/bars mapping,  PLAYER ONLY
CurvyHud.statTypeBarMapping = {
	[STAT_HEALTH_REGEN_COMBAT] 	= "healthBar", 
	[STAT_STAMINA_REGEN_COMBAT] = "staminaBar", 
	[STAT_MAGICKA_REGEN_COMBAT] = "magickaBar", 
}

-- font list
CurvyHud.fontList = {
	["ProseAntique"]		= "EsoUI/Common/Fonts/ProseAntiquePSMT.otf", 
	["Consolas"]			= "EsoUI/Common/Fonts/consola.ttf", 
	["ESO Cartographer"]	= "EsoUI/Common/Fonts/esocartographer-bold.otf", 
	["Skyrim Handwritten"]	= "EsoUI/Common/Fonts/Handwritten_Bold.otf", 
	["Trajan Pro"]			= "EsoUI/Common/Fonts/trajanpro-regular.otf", 
	["Univers 55"]			= "EsoUI/Common/Fonts/univers55.otf", 
	["Univers 57"]			= "EsoUI/Common/Fonts/univers57.otf", 
	["Univers 67"]			= "EsoUI/Common/Fonts/univers67.otf", 
}

-- bar table
CurvyHud.barList = { 
	[1] = "healthBar", 
	[2] = "targetBar", 
	[3] = "magickaBar", 
	[4] = "staminaBar", 
	[5] = "mountBar", 
	[6] = "siegeBar", 
	[7] = "werewolfBar", 
}

-- Combat Unit Type
CurvyHud.CombatUnitType = {
	[0] = COMBAT_UNIT_TYPE_NONE,
	[1] = COMBAT_UNIT_TYPE_PLAYER,
	[2] = COMBAT_UNIT_TYPE_PLAYER_PET,
	[3] = COMBAT_UNIT_TYPE_GROUP,
	[4] = COMBAT_UNIT_TYPE_TARGET_DUMMY,
	[5] = COMBAT_UNIT_TYPE_OTHER, 	-- must be a real player
}

-- Visuals Effects
CurvyHud.visualsEffects = {

	[38541] = "TAUNT",
	--
	-- MAJOR TABLE
	--	
	-- Major Breach (down migical resist)
	[33363] = "MAJOR_BREACH",
	[36972] = "MAJOR_BREACH",
	[36980] = "MAJOR_BREACH",
	[53881] = "MAJOR_BREACH",
	[61743] = "MAJOR_BREACH",
	[62485] = "MAJOR_BREACH",
	[62775] = "MAJOR_BREACH",
	[62787] = "MAJOR_BREACH",
	[78609] = "MAJOR_BREACH",
	[89054] = "MAJOR_BREACH",
	[91200] = "MAJOR_BREACH",
	[93452] = "MAJOR_BREACH",
	[108951] = "MAJOR_BREACH",
	[117818] = "MAJOR_BREACH",
	[118438] = "MAJOR_BREACH",
	[120010] = "MAJOR_BREACH",
	-- Major Resolve (up physical resist)
	[22236] = "MAJOR_RESOLVE",
	[44828] = "MAJOR_RESOLVE",
	[44836] = "MAJOR_RESOLVE",
	[61694] = "MAJOR_RESOLVE",
	[61815] = "MAJOR_RESOLVE",
	[61827] = "MAJOR_RESOLVE",
	[61836] = "MAJOR_RESOLVE",
	[62159] = "MAJOR_RESOLVE",
	[62168] = "MAJOR_RESOLVE",
	[62175] = "MAJOR_RESOLVE",
	[63084] = "MAJOR_RESOLVE",
	[63119] = "MAJOR_RESOLVE",
	[63134] = "MAJOR_RESOLVE",
	[66075] = "MAJOR_RESOLVE",
	[66083] = "MAJOR_RESOLVE",
	[80160] = "MAJOR_RESOLVE",
	[86224] = "MAJOR_RESOLVE",
	[88758] = "MAJOR_RESOLVE",
	[88761] = "MAJOR_RESOLVE",
	[91194] = "MAJOR_RESOLVE",
	[103752] = "MAJOR_RESOLVE",
	[107632] = "MAJOR_RESOLVE",
	[115211] = "MAJOR_RESOLVE",
	[116805] = "MAJOR_RESOLVE",
	[118239] = "MAJOR_RESOLVE",
	[118246] = "MAJOR_RESOLVE",
    [130633] = "MAJOR_RESOLVE",
	-- Major Fracture
	[28307] = "MAJOR_FRACTURE",
	[34386] = "MAJOR_FRACTURE",
    [40254] = "MAJOR_FRACTURE",
	[48946] = "MAJOR_FRACTURE",
	[61741] = "MAJOR_FRACTURE",
	[62474] = "MAJOR_FRACTURE",
	[62484] = "MAJOR_FRACTURE",
	[63909] = "MAJOR_FRACTURE",
	[63915] = "MAJOR_FRACTURE",
	[63919] = "MAJOR_FRACTURE",
	[78608] = "MAJOR_FRACTURE",
	[85362] = "MAJOR_FRACTURE",
	[89055] = "MAJOR_FRACTURE",
	[91175] = "MAJOR_FRACTURE",
	[91204] = "MAJOR_FRACTURE",
	[93451] = "MAJOR_FRACTURE",
	[94444] = "MAJOR_FRACTURE",
	[100988] = "MAJOR_FRACTURE",
	[111788] = "MAJOR_FRACTURE",
	[118437] = "MAJOR_FRACTURE",
	[120022] = "MAJOR_FRACTURE",
	[117819] = "MAJOR_FRACTURE",
	-- Major Ward (up migical resist)
	[61696] = "MAJOR_WARD",
	[91195] = "MAJOR_WARD",
	
	--
	-- MINOR TABLE
	--
	-- Minor Breach (down phyisical resist)
	[46206] = "MINOR_BREACH", 
	[46248] = "MINOR_BREACH",
	[61742] = "MINOR_BREACH",
	[68588] = "MINOR_BREACH",
	[79086] = "MINOR_BREACH",
	[79087] = "MINOR_BREACH",
	[79284] = "MINOR_BREACH",
	[79306] = "MINOR_BREACH",
	[83031] = "MINOR_BREACH",
	[108825] = "MINOR_BREACH",
	[120019] = "MINOR_BREACH",
    [126685] = "MINOR_BREACH",
	-- Glyph of weapon to reduce physical and magical resist
	[17906] = "MINOR_ALL",
	-- Minor Fracture
	[38688] = "MINOR_FRACTURE",
	[46208] = "MINOR_FRACTURE",
	[46250] = "MINOR_FRACTURE",
	[60416] = "MINOR_FRACTURE",
	[61740] = "MINOR_FRACTURE",
	[64144] = "MINOR_FRACTURE",
	[79090] = "MINOR_FRACTURE",
	[79091] = "MINOR_FRACTURE",
	[79309] = "MINOR_FRACTURE",
	[79311] = "MINOR_FRACTURE",
	[83032] = "MINOR_FRACTURE",
	[84358] = "MINOR_FRACTURE",
	[120027] = "MINOR_FRACTURE",
    [126684] = "MINOR_FRACTURE",
	-- Minor Resolve
	[37247] = "MINOR_RESOLVE",
	[61693] = "MINOR_RESOLVE",
	[61817] = "MINOR_RESOLVE",
	[62626] = "MINOR_RESOLVE",
	[62634] = "MINOR_RESOLVE",
	[108856] = "MINOR_RESOLVE",
	-- Minor Ward
	[61695] = "MINOR_WARD",	
}

CurvyHud.zonesIndex = {
	-- Dungeons
    [3] 	= "Dungeon", -- Chambres de la folie / Vaults of Madness	
    [6] 	= "Dungeon", -- Volenfell
    [7] 	= "Dungeon", -- Toile de Sélène / Selene's Web	
    [8] 	= "Dungeon", -- Havre de coeurnoir / Blackheart Haven
    [12] 	= "Dungeon", -- Caverne d'Ombrenoire I / Darkshade Caverns I
	[13] 	= "Dungeon", -- Creuset bénit / Blessed Crucible
    [21] 	= "Dungeon", -- Creuset des Ainés I/ Elden Hollow I
    [22] 	= "Dungeon", -- Crypte des coeurs I / Crypt of Hearts I
    [23] 	= "Dungeon", -- L'île des tempêtes / Tempest Island
    [28] 	= "Dungeon", -- Tressefuseau I / Spindleclutch I
    [29] 	= "Dungeon", -- Egouts d'Haltevoie I / Wayrest Sewers I	
    [30] 	= "Dungeon", -- Arx Corinium
    [36] 	= "Dungeon", -- Cité des cendres I / City of Ash I
    [111] 	= "Dungeon", -- Champi I / Fungal Grotto I	
    [177] 	= "Dungeon", -- Le cachot interdit I / The Banished Cells I
	[235] 	= "Dungeon", -- Donjon d'Affregivre / Direfrost Keep
    [377] 	= "Dungeon", -- Prison de la Cité Impérial / Imperial City Prison
	[378] 	= "Dungeon", -- Cité des cendres II / City of Ash II
	[380] 	= "Dungeon", -- Tour de l'Or blanc / White-Gold Tower
	[463] 	= "Dungeon", -- Ruines de Mazzatun / Ruins of Mazzatun
    [466]	= "Dungeon", -- Berceau des Ombres / Cradle of Shadows
    [541] 	= "Dungeon", -- Caverne d'Ombrenoire II / Darkshade Caverns II	
    [542] 	= "Dungeon", -- Creuset des ainés II / Elden Hollow II
    [543] 	= "Dungeon", -- Crypte des coeurs II / Crypt of Hearts II	
    [544] 	= "Dungeon", -- Egouts d'Haltevoie II / Wayrest Sewers II
    [545] 	= "Dungeon", -- Champi II / Fungal Grotto II
    [546] 	= "Dungeon", -- Le cachot interdit II / The Banished Cells II	
    [547]	= "Dungeon", -- Tressefuseau II	/ Spindleclutch II
	[584] 	= "Dungeon", -- Forge de Sangracine / Bloodroot Forge
    [584] 	= "Dungeon", -- Forteresse d'Epervine / Falkreath Hold
	[614] 	= "Dungeon", -- Repaire du Croc
	[615] 	= "Dungeon", -- Pique de Mandécailles / Scalecaller Peak
	[654]	= "Dungeon", -- Fort du chasseur lunaire / Moon Hunter Keep
	[655] 	= "Dungeon", -- Pressession des sacrifiés / March of Sacrifices
	[676]	= "Dungeon", -- Donjon d'Arquegivre
	[677]	= "Dungeon", -- Profondeur de Malatar
	[678]	= "Dungeon", -- La prison de la rose noire
    [703] 	= "Dungeon", -- Prison de la Rose Noire
	[713]	= "Dungeon", -- Reliquaire des lunes funèbres
	[714]	= "Dungeon", -- Le repaire de Maarselok
	[739]	= "Dungeon", -- Crève-Néve
	[740]	= "Dungeon", -- Le sépulcre profane
	-- Raids
--	[365]	= "Raid", -- Arène du Dragon	
    [366] 	= "Raid", -- Hel Ra Citadel
    [368] 	= "Raid", -- Archives Aetheriennes / Aetherian Archives
    [369]	= "Raid", -- Sanctum d'Ophidia
--	[376]	= "Raid", -- Arène du Maelstrom
    [406] 	= "Raid", -- Maw of Lorkhaj
	[586]	= "Raid", -- Salle des facrication
	[635] 	= "Raid", -- Asylum Sanctorium
	[653]	= "Raid", -- Pas des nuées / Cloudrest
	[712]	= "Raid", -- Sollance
	[774]	= "Raid", -- Egide de Kyne
}