--[[----------------------------------------------------------
    CurvyHud 
    ----------------------------------------------------------

	Localization 	: 	/Datas/Textures.lua 
	
    Original Author	:	Niocwy
	Update Author 	:	Vvarderen
    Version			: 	6.12
    Updated			:  	2020-06-20 (YYYY-MM-DD)
----------------------------------------------------------]]--

CurvyHud.textures			= {
--------------
-- FRAMES BARS
--------------
	-- Ehancedbars, created by Cédric D. and Vvarderen
	default		= {
		fileLeft		= CurvyHud.name .. "/textures/frames/default_left.dds", 
		fileRight 		= CurvyHud.name .. "/textures/frames/default_right.dds", 
		coords 			= {
			background 		= 	{0	   	  , 72  /2048, 	0, 1},
			border	 		= 	{73  /2048,	145 /2048, 	0, 1},
			full			= 	{146 /2048,	218 /2048, 	0, 1},
			filler 			= 	{219 /2048,	291 /2048, 	0, 1},
			degen 			= 	{292 /2048,	363 /2048, 	0, 1},
			regen 			= 	{364 /2048,	446 /2048, 	0, 1},
			phys_major_Dec	= 	{447 /2048,	518 /2048, 	0, 1},
			phys_major_Inc	= 	{519 /2048,	591 /2048, 	0, 1},
			spell_major_Dec	= 	{592 /2048,	664 /2048, 	0, 1},
			spell_major_Inc	= 	{665 /2048,	737 /2048, 	0, 1},
			phys_minor_Dec	= 	{738 /2048,	810 /2048, 	0, 1},
			phys_minor_Inc	= 	{811 /2048,	883 /2048, 	0, 1},
			spell_minor_Dec	= 	{884 /2048,	956 /2048, 	0, 1},
			spell_minor_Inc	= 	{957 /2048,	1029/2048, 	0, 1},
			phys_major_Dual = 	{1030/2048,	1102/2048,	0, 1},
			phys_minor_Dual =	{1103/2048,	1175/2048,	0, 1},
			spell_major_Dual =	{1176/2048,	1248/2048,	0, 1},
			spell_minor_Dual =	{1249/2048,	1321/2048,	0, 1},
		}, 
		barWidth			= 72, 
		barHeight 			= 512, 
		barThickness 		= 28, 
		stepSize 			= 35, 
		borderSize			= 2, 
		borderMargin		= 1, 
		textureHeight		= 512, 
	}, 
	-- Faltbars, Vvarderen
	flat		= {
		fileLeft		= CurvyHud.name .. "/textures/frames/flat_left.dds", 
		fileRight 		= CurvyHud.name .. "/textures/frames/flat_right.dds", 
		coords 			= {
			background 		= 	{0	   	  , 72  /2048, 	0, 1},
			border	 		= 	{73  /2048,	145 /2048, 	0, 1},
			full			= 	{146 /2048,	218 /2048, 	0, 1},
			filler 			= 	{219 /2048,	291 /2048, 	0, 1},
			degen 			= 	{292 /2048,	363 /2048, 	0, 1},
			regen 			= 	{364 /2048,	446 /2048, 	0, 1},
			phys_major_Dec	= 	{447 /2048,	518 /2048, 	0, 1},
			phys_major_Inc	= 	{519 /2048,	591 /2048, 	0, 1},
			spell_major_Dec	= 	{592 /2048,	664 /2048, 	0, 1},
			spell_major_Inc	= 	{665 /2048,	737 /2048, 	0, 1},
			phys_minor_Dec	= 	{738 /2048,	810 /2048, 	0, 1},
			phys_minor_Inc	= 	{811 /2048,	883 /2048, 	0, 1},
			spell_minor_Dec	= 	{884 /2048,	956 /2048, 	0, 1},
			spell_minor_Inc	= 	{957 /2048,	1029/2048, 	0, 1},
			phys_major_Dual = 	{1030/2048,	1102/2048,	0, 1},
			phys_minor_Dual =	{1103/2048,	1175/2048,	0, 1},
			spell_major_Dual =	{1176/2048,	1248/2048,	0, 1},
			spell_minor_Dual =	{1249/2048,	1321/2048,	0, 1},
		}, 
		barWidth			= 72, 
		barHeight 			= 512, 
		barThickness 		= 28, 
		stepSize 			= 35, 
		borderSize			= 2, 
		borderMargin		= 1, 
		textureHeight		= 512, 
	}, 
	-- Oblivionbars, created by Vvarderen
	oblivion		= {
		fileLeft		= CurvyHud.name .. "/textures/frames/oblivion_left.dds", 
		fileRight 		= CurvyHud.name .. "/textures/frames/oblivion_right.dds", 
		coords 			= {
			background 		= 	{0	   	  , 72  /2048, 	0, 1},
			border	 		= 	{73  /2048,	145 /2048, 	0, 1},
			full			= 	{146 /2048,	218 /2048, 	0, 1},
			filler 			= 	{219 /2048,	291 /2048, 	0, 1},
			degen 			= 	{292 /2048,	363 /2048, 	0, 1},
			regen 			= 	{364 /2048,	446 /2048, 	0, 1},
			phys_major_Dec	= 	{447 /2048,	518 /2048, 	0, 1},
			phys_major_Inc	= 	{519 /2048,	591 /2048, 	0, 1},
			spell_major_Dec	= 	{592 /2048,	664 /2048, 	0, 1},
			spell_major_Inc	= 	{665 /2048,	737 /2048, 	0, 1},
			phys_minor_Dec	= 	{738 /2048,	810 /2048, 	0, 1},
			phys_minor_Inc	= 	{811 /2048,	883 /2048, 	0, 1},
			spell_minor_Dec	= 	{884 /2048,	956 /2048, 	0, 1},
			spell_minor_Inc	= 	{957 /2048,	1029/2048, 	0, 1},
			phys_major_Dual = 	{1030/2048,	1102/2048,	0, 1},
			phys_minor_Dual =	{1103/2048,	1175/2048,	0, 1},
			spell_major_Dual =	{1176/2048,	1248/2048,	0, 1},
			spell_minor_Dual =	{1249/2048,	1321/2048,	0, 1},
		}, 
		barWidth			= 72, 
		barHeight 			= 512, 
		barThickness 		= 28, 
		stepSize 			= 35, 
		borderSize			= 2, 
		borderMargin		= 1, 
		textureHeight		= 512, 
	}, 
	-- Ghostlybars, created by Vvarderen
	ghostly		= {
		fileLeft		= CurvyHud.name .. "/textures/frames/ghostly_left.dds", 
		fileRight 		= CurvyHud.name .. "/textures/frames/ghostly_right.dds", 
		coords 			= {
			background 		= 	{0	   	 , 	100 /2048, 	0, 1},
			full			= 	{100 /2048,	200 /2048, 	0, 1},
			filler 			= 	{200 /2048,	300 /2048, 	0, 1},
			degen 			= 	{300 /2048,	400 /2048, 	0, 1},
			regen 			= 	{400 /2048,	500 /2048, 	0, 1},
			phys_major_Dec	= 	{500 /2048,	600 /2048, 	0, 1},
			phys_major_Inc	= 	{600 /2048,	700 /2048, 	0, 1},
			spell_major_Dec	= 	{700 /2048,	800 /2048, 	0, 1},
			spell_major_Inc	= 	{800 /2048,	900 /2048, 	0, 1},
			phys_minor_Dec	= 	{900 /2048,	1000/2048, 	0, 1},
			phys_minor_Inc	= 	{1000/2048,	1100/2048, 	0, 1},
			spell_minor_Dec	= 	{1100/2048,	1200/2048, 	0, 1},
			spell_minor_Inc	= 	{1200/2048,	1300/2048, 	0, 1},
			phys_major_Dual = 	{1300/2048,	1400/2048,	0, 1},
			phys_minor_Dual =	{1400/2048,	1500/2048,	0, 1},
			spell_major_Dual =	{1500/2048,	1600/2048,	0, 1},
			spell_minor_Dual =	{1600/2048,	1700/2048,	0, 1},
			border	 		= 	{2047/2048,	2047/2048, 	0, 1},
		}, 
		barWidth			= 100,
		barHeight 			= 512,
		barThickness 		= 28,
		stepSize 			= 0,
		borderSize			= 0,
		borderMargin		= 0,
		textureHeight		= 512,
	}, 

------------------
-- BOSS DIFFICULTY
------------------	
	-- Asterix style character, created by Vvarderen - Originaly text by Niocwy
	default_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/boss_normal.dds",
		hard		= CurvyHud.name .. "/textures/diff/boss_hard.dds",
		deadly		= CurvyHud.name .. "/textures/diff/boss_deadly.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/boss_deadly.dds",
	}, 
	-- Star style, created by Vvarderen
	star_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/star_normal.dds",
		hard		= CurvyHud.name .. "/textures/diff/star_hard.dds",
		deadly		= CurvyHud.name .. "/textures/diff/star_deadly.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/star_deadly.dds",
	}, 
	-- Double swords style, created by Vvarderen
	dsword_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/dsword_normal.dds",
		hard		= CurvyHud.name .. "/textures/diff/dsword_hard.dds",
		deadly		= CurvyHud.name .. "/textures/diff/dsword_deadly.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/dsword_deadly.dds",
	}, 
	-- Oblivion style,  created by Vvarderen
	obli_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/obli_normal.dds",
		hard		= CurvyHud.name .. "/textures/diff/obli_hard.dds",
		deadly		= CurvyHud.name .. "/textures/diff/obli_deadly.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/obli_deadly.dds",
	}, 
	-- Skull style, created by Vvarderen
	skull_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/skull_normal.dds",
		hard		= CurvyHud.name .. "/textures/diff/skull_hard.dds",
		deadly		= CurvyHud.name .. "/textures/diff/skull_deadly.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/skull_deadly.dds",
	}, 
	-- NoneIcon style, created by Vvarderen
	noneIcon_boss	= {
		normal		= CurvyHud.name .. "/textures/diff/none.dds",
		hard		= CurvyHud.name .. "/textures/diff/none.dds",
		deadly		= CurvyHud.name .. "/textures/diff/none.dds",
		none		= CurvyHud.name .. "/textures/diff/none.dds",
		guard		= CurvyHud.name .. "/textures/diff/none.dds",
	}, 
}